# == Schema Information
#
# Table name: global_configs
#
#  id                     :integer          not null, primary key
#  bid_review_enabled     :boolean          default(TRUE)
#  bid_submission_enabled :boolean          default(TRUE)
#  comments_enabled       :boolean          default(TRUE)
#  questions_enabled      :boolean          default(TRUE)
#  event_hooks            :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require_dependency 'enum'

class GlobalConfig < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  acts_as_singleton

  serialize :event_hooks, Hash

  def self.event_hooks
    @event_hooks ||= Enum.new(
      :twitter, :custom_http
    )
  end

  def self.event_hook_name_for(event_hook)
    {
      :twitter => "Twitter",
      :custom_http => "Custom HTTP"
    }[event_hook.to_sym]
  end

  def run_event_hooks_for_project!(project)
    event_hooks.select { |k, v| v['enabled'] }.each do |k, v|
      case k
      when GlobalConfig.event_hooks[:twitter]
        client = ProcureIoTwitterOAuth.client(token: v['oauth_token'], secret: v['oauth_token_secret'])
        client.update(
          truncate(v['tweet_body'].gsub(':title', project.title)
                                  .gsub(':bids_due_at', project.bids_due_at.to_formatted_s(:readable_dateonly)),
                   length: 140)
        )

      when GlobalConfig.event_hooks[:custom_http]
        HTTParty.post(v['url'],
                      body: ProjectSerializer.new(project, root: false).to_json,
                      headers: { 'Content-Type' => 'application/json' } ) rescue ArgumentError
      end
    end
  end
end
