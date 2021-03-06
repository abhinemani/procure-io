# @todo security
class FormTemplatesController < ApplicationController
  def create
    @project = Project.find(params[:project_id])

    response_fields = []

    @project.response_fields.each do |response_field|
      response_fields.push({
        label: response_field.label,
        field_type: response_field.field_type,
        field_options: response_field.field_options,
        sort_order: response_field.sort_order,
        key_field: response_field.key_field
      })
    end

    logger.info response_fields

    @form_template = FormTemplate.create(name: params[:name],
                                         response_fields: response_fields,
                                         form_description: @project.form_description,
                                         form_confirmation_message: @project.form_confirmation_message)

    respond_to do |format|
      format.json { render json: @form_template }
    end
  end
end
