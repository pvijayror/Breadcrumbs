class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = Task.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
    @open_breadcrumbs = @task.breadcrumbs.find_open
    @closed_breadcrumbs = @task.breadcrumbs.find_closed
    @status_list = Task.build_status_list
    if @task.parent
      @parent_task = Task.find(@task.parent)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new
    @status_list = Task.build_status_list
    @effort_list = Task.build_effort_list

    if params[:project_id]
      @project = Project.find(params[:project_id])
      @task_list = Task.find_for_project( @project ).collect {|t| [ t.name, t.id ] }
      @task.project = @project 
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
    @status_list = Task.build_status_list
    @project_list = Project.find(:all).collect {|p| [ p.name, p.id ] }
    @task_list = Task.find_others_for_project( @task ).collect {|t| [ t.name, t.id ] }
    @effort_list = Task.build_effort_list
  end

  def mark_done 
    @task = Task.find(params[:id])
    @task.status_id = Task::DONE_STATUS
    @task.working = false
    @task.save!

    redirect_to @task.project(:task_status_to_display => params[:task_status_to_display])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])


    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])
    logger.debug( "updating task #{@task.name}")
    respond_to do |format|
      if params[:status_id]
        @task.update_attributes(:status_id => params[:status_id])
        format.html { redirect_to(@task) }
      elsif @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end
end
