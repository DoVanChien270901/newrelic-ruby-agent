# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require_relative 'request_wrapper'
require_relative '../helper'

module NewRelic
  module Agent
    module Instrumentation
      module GRPC
        module Client
          include NewRelic::Agent::Instrumentation::GRPC::Helper

          def initialize_with_tracing(*args)
            instance = yield
            # TODO - find out whether we should set the variable on instance or self
            instance.instance_variable_set(:@trace_with_newrelic, trace_with_newrelic?(args.first))
            instance
          end

          def issue_request_with_tracing(method, requests, marshal, unmarshal,
            deadline:, return_op:, parent:, credentials:, metadata:)
            return yield unless trace_with_newrelic?

            segment = request_segment(method)
            request_wrapper = NewRelic::Agent::Instrumentation::GRPC::Client::RequestWrapper.new(@host)
            segment.add_request_headers(request_wrapper)

            metadata.merge!(metadata, request_wrapper.instance_variable_get(:@newrelic_metadata))
            set_distributed_tracing_headers(metadata)

            NewRelic::Agent.disable_all_tracing do
              NewRelic::Agent::Tracer.capture_segment_error(segment) do
                yield
              end
            end
          ensure
            segment.finish if segment
          end

          private

          def request_segment(method)
            cleaned = cleaned_method(method)
            NewRelic::Agent::Tracer.start_external_request_segment(
              library: 'gRPC',
              uri: method_uri(cleaned),
              procedure: cleaned
            )
          end

          def method_uri(method)
            return unless @host && method

            "grpc://#{@host}/#{method}"
          end

          def set_distributed_tracing_headers(metadata)
            return unless ::NewRelic::Agent.config[:'distributed_tracing.enabled']

            ::NewRelic::Agent::DistributedTracing.insert_distributed_trace_headers(metadata)
          end

          def trace_with_newrelic?(host = nil)
            return false if self.class.name.eql?('GRPC::InterceptorRegistry')

            do_trace = instance_variable_get(:@trace_with_newrelic)
            return do_trace unless do_trace.nil?

            host ||= @host
            return false unless host && !host_denylisted?(host)

            true
          end

          def host_denylisted?(host)
            NewRelic::Agent.config[:'instrumentation.grpc.host_denylist'].any? do |regex|
              host.match?(regex)
            end
          end
        end
      end
    end
  end
end
