# Helps us respond with a topic list from a controller
module TopicListResponder

  def insert_advertisements_into_list(list, advertisement, occurence)
    advertisement_occurence = 0

    list.count.times do |x|
      if x != 0 && x % occurence == 0
        list.insert(x + advertisement_occurence, advertisement)
        advertisement_occurence += 1
      end
    end
  end

  def respond_with_list(list)
    discourse_expires_in 1.minute

    list.draft_key = Draft::NEW_TOPIC
    list.draft_sequence = DraftSequence.current(current_user, Draft::NEW_TOPIC)
    list.draft = Draft.get(current_user, list.draft_key, list.draft_sequence) if current_user

    topic = Topic.new(is_advertisement: true)

    list_items = list.topics if list.respond_to?(:topics)
    list_items = list.suggested_topics if list.respond_to?(:suggested_topics)

    insert_advertisements_into_list(list_items, topic, 3)

    respond_to do |format|
      format.html do
        @list = list
        store_preloaded(list.preload_key, MultiJson.dump(TopicListSerializer.new(list, scope: guardian)))
        render 'list/list'
      end
      format.json do
        render_serialized(list, TopicListSerializer)
      end
    end
  end

end

