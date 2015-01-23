
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish on, actor, story_defs, object_data_url
    raise 'abstract method called'
  end

  def url_for url
    return url if url.is_a? String
    Noosfero::Application.routes.url_helpers.url_for url.except(:port)
  end

  def publish_stories object_data, on, actor, stories
    stories.each do |story|
      defs = OpenGraphPlugin::Stories::Definitions[story]

      match_criteria = if defs[:criteria] then defs[:criteria].call(object_data) else true end
      next unless match_criteria
      match_condition = if defs[:publish_if] then defs[:publish_if].call(object_data) else true end
      next unless match_condition
      match_track = actor.open_graph_track_configs.where(object_type: defs[:object_type]).count > 0
      next unless match_track

      if defs[:publish]
        defs[:publish].call actor, object_data, self
      else
        object_data_url = if defs[:object_data_url] then defs[:object_data_url].call(object_data) else object_data.url end
        object_data_url = self.url_for object_data_url

        if defs[:tracker]
          exclude_actor = actor
          trackers = OpenGraphPlugin::Track.profile_trackers object_data, exclude_actor
          trackers.each do |tracker|
            publish on, tracker.tracker, defs, object_data_url
          end
        else
          publish on, actor, defs, object_data_url
        end
      end
    end
  end

end

