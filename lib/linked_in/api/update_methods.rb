module LinkedIn
  module Api

    module UpdateMethods

      def add_share(share)
        path = "/people/~/shares"
        defaults = {:visibility => {:code => "anyone"}}
        post(path, defaults.merge(share).to_json, "Content-Type" => "application/json")
      end

      def send_message(subject, body, recipient_paths)
        path = "/people/~/mailbox"

        message         = LinkedIn::Message.new
        message.subject = subject
        message.body    = body
        recipients      = LinkedIn::Recipients.new

        recipients.recipients = recipient_paths.map do |profile_path|
          Struct.new(:person).new(Struct.new(:path).new("/people/#{profile_path}"))
        end

        message.recipients = recipients
        post(path, message_to_xml(message)).code
      end
      
      def comment_to_xml(comment)
        doc = Nokogiri.XML('<update-comment><comment/><update-comment/>')
        doc.encoding = 'UTF-8'
        doc.at_css('comment').content = comment
        doc.to_xml
      end
      
      def update_comment(network_key, comment)
        path = "/people/~/network/updates/key=#{network_key}/update-comments"
        post(path, comment_to_xml(comment))
      end
      
      %w[like unlike].each do |liking|
        define_method liking do |network_key|
          path = "/people/~/network/updates/key=#{network_key}/is-liked"
          xml = "<?xml version='1.0' encoding='UTF-8'?>\n<is-liked>#{liking == 'like'}</is-liked>"
          put(path, xml, "Content-Type" => "application/xml", "x-li-format" => 'xml')
        end
      end
      #
      # def update_network(message)
      #   path = "/people/~/person-activities"
      #   post(path, network_update_to_xml(message))
      # end
      #
      # def send_message(subject, body, recipient_paths)
      #   path = "/people/~/mailbox"
      #
      #   message         = LinkedIn::Message.new
      #   message.subject = subject
      #   message.body    = body
      #   recipients      = LinkedIn::Recipients.new
      #
      #   recipients.recipients = recipient_paths.map do |profile_path|
      #     recipient             = LinkedIn::Recipient.new
      #     recipient.person      = LinkedIn::Person.new
      #     recipient.person.path = "/people/#{profile_path}"
      #     recipient
      #   end
      #   message.recipients = recipients
      #   post(path, message_to_xml(message)).code
      # end
      #
      # def clear_status
      #   path = "/people/~/current-status"
      #   delete(path).code
      # end
      #

    end

  end
end

module LinkedIn
  class Message

    attr_accessor :subject, :body, :recipients
  
    def to_xml
      self.to_xml_node(Nokogiri.XML('<root/>', nil, 'UTF-8')).to_xml
    end

    def to_xml_node(doc)
      node = Nokogiri::XML::DocumentFragment.new(doc, '<mailbox-item><recipients/><subject/><body/></mailbox-item>')
      node.at_css('recipients').add_child(self.recipients.to_xml_nodes(doc))
      node.at_css('subject').content = self.subject
      node.at_css('body').content = self.body
      node
    end

  end

end
