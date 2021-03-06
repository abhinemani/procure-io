class CollaboratorsController < ApplicationController
  before_filter :project_exists?
  before_filter :authenticate_officer!

  def index
    current_officer.read_notifications(@project, :collaborator_added, :you_were_added)
    @collaborators_json = ActiveModel::ArraySerializer.new(@project.collaborators).to_json
  end

  def create
    @officer = Officer.where(email: params[:officer][:email]).first || Officer.invite!(email: params[:officer][:email])

    if @officer.projects.where(id: @project.id).first
      respond_to do |format|
        format.json { render json: {error: "Already a collaborator."}, status: 422 }
      end
    else
      @collaborator = @officer.collaborators.create(project_id: @project.id, added_by_officer_id: current_officer.id)
      respond_to do |format|
        format.json { render json: @collaborator, root: false }
      end
    end
  end

  def destroy
    authorize! :destroy, @project # only the owner of the project can remove collaborators
    @project.collaborators.find(params[:id]).destroy

    respond_to do |format|
      format.json { render json: {} }
    end
  end

  private
  def project_exists?
    @project = Project.find(params[:project_id])
    authorize! :collaborate_on, @project
  end
end
