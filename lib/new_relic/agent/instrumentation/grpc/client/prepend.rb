# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require_relative 'instrumentation'

module NewRelic
  module Agent
    module Instrumentation
      module GRPC
        module Client
          module Prepend
            include NewRelic::Agent::Instrumentation::GRPC::Client

            def initialize(*args)
              initialize_with_tracing(*args) { super(*args) }
            end

            def bidi_streamer(method, requests, marshal, unmarshal,
              deadline: nil,
              return_op: false,
              parent: nil,
              credentials: nil,
              metadata: {},
              &blk)

              issue_request_with_tracing(method, requests, marshal, unmarshal,
                deadline: deadline,
                return_op: return_op,
                parent: parent,
                credentials: credentials,
                metadata: metadata) do
                  super(method, requests, marshal, unmarshal,
                        deadline: deadline,
                        return_op: return_op,
                        parent: parent,
                        credentials: credentials,
                        metadata: metadata,
                        &blk)
                end
            end

            def client_streamer(method, requests, marshal, unmarshal,
              deadline: nil,
              return_op: false,
              parent: nil,
              credentials: nil,
              metadata: {})

              issue_request_with_tracing(method, requests, marshal, unmarshal,
                deadline: deadline,
                return_op: return_op,
                parent: parent,
                credentials: credentials,
                metadata: metadata) do
                  super(method, requests, marshal, unmarshal,
                        deadline: deadline,
                        return_op: return_op,
                        parent: parent,
                        credentials: credentials,
                        metadata: metadata)
                end
            end

            def request_response(method, req, marshal, unmarshal,
              deadline: nil,
              return_op: false,
              parent: nil,
              credentials: nil,
              metadata: {})

              issue_request_with_tracing(method, req, marshal, unmarshal,
                deadline: deadline,
                return_op: return_op,
                parent: parent,
                credentials: credentials,
                metadata: metadata) do
                  super(method, req, marshal, unmarshal,
                        deadline: deadline,
                        return_op: return_op,
                        parent: parent,
                        credentials: credentials,
                        metadata: metadata)
                end
            end

            def server_streamer(method, req, marshal, unmarshal,
              deadline: nil,
              return_op: false,
              parent: nil,
              credentials: nil,
              metadata: {},
              &blk)

              issue_request_with_tracing(method, req, marshal, unmarshal,
                deadline: deadline,
                return_op: return_op,
                parent: parent,
                credentials: credentials,
                metadata: metadata) do
                  super(method, req, marshal, unmarshal,
                        deadline: deadline,
                        return_op: return_op,
                        parent: parent,
                        credentials: credentials,
                        metadata: metadata,
                        &blk)
                end
            end
          end
        end
      end
    end
  end
end
