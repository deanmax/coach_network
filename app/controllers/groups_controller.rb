class GroupsController < ApplicationController
  before_action :signed_in_user, only: [:new, :create, :destroy]
  before_action :correct_coach,   only: [:edit, :update, :destroy]
  

  def index
    if request.format.to_sym == :html
      @groups = Group.paginate(page: params[:page])
    else
      @groups = Group.all
    end
    
    respond_to do |format|
      format.html { render html:@groups }
      format.json { render json:@groups }
      format.xml { render xml: @groups }
    end
    
  end
  
  def search
    @groups = Group.search do
      fulltext params[:query]
      paginate(:per_page => 100)
      
    end.results

    respond_to do |format|
      format.html { render :action => "index" }
      format.xml  { render :xml => @groups }
    end
  end

  def new
    @group = current_coach.groups.build
  end
  
  def create
    @group = current_coach.groups.build(group_params)
    if @group.save
      flash[:success] = "Group created!"
      redirect_to group_path(@group)
    else
      render 'new'
    end
  end
  
  
  
  def show
    @group = Group.find(params[:id])
    $current_group = @group
    @post = @group.posts.build if signed_in?
    @posts = @group.posts.paginate(page: params[:page])
    @enrollments = @group.enrollments
    if student_signed_in?
      @rating = Rating.where(group_id: @group.id, student_id: @current_student.id).first
        unless @rating
        @rating = Rating.create(group_id: @group.id, student_id: @current_student.id, score: 0)
        end
    end
  end
  
  def edit
    @group = Group.find(params[:id])
    
  end
  
  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated"
      redirect_to @group    
    else
      render 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    flash[:success] = "Group destroyed"
    redirect_to coach_path(current_coach)
  end
  
  private
  
      def group_params
        params.require(:group).permit(:name,:description,:location, :schedule)
      end
      
      def correct_coach
        @group = Group.find(params[:id])
        redirect_to(root_path) unless (current_coach.id == @group.coach_id || current_coach.admin?)
      end
      
end