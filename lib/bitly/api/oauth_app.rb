# frozen_string_literal: true
require_relative "./base"

module Bitly
  module API
    class OAuthApp
      include Base

      def self.attributes
        [:name, :description, :link, :client_id]
      end
      attr_reader(*attributes)

      def self.fetch(client: nil, client_id: nil)
        response = client.request(path: "/apps/#{client_id}")
        new(data: response.body, client: client, response: response)
      end

      def initialize(data: nil, client: nil, response: nil)
        assign_attributes(data)
        @client = client
        @response = response
      end
    end
  end
end