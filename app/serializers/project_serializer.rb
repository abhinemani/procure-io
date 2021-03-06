class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :abstract, :body, :bids_due_at, :posted_at, :key_fields, :bids_due_at_readable, :posted_at_readable,
             :bids_due_at_readable_dateonly, :posted_at_readable_dateonly, :form_description, :form_confirmation_message

  has_many :tags
  has_many :labels

  def abstract
    object.abstract_or_truncated_body
  end

  def bids_due_at_readable
    object.bids_due_at.to_formatted_s(:readable) if object.bids_due_at
  end

  def posted_at_readable
    object.posted_at.to_formatted_s(:readable) if object.posted_at
  end

  def bids_due_at_readable_dateonly
    object.bids_due_at.to_formatted_s(:readable_dateonly) if object.bids_due_at
  end

  def posted_at_readable_dateonly
    object.posted_at.to_formatted_s(:readable_dateonly) if object.posted_at
  end
end
