require 'travis/scheduler/model/update_count'

module Travis
  module Scheduler
    module Service
      class EnqueueJob < Struct.new(:context, :job, :opts)
        include Registry, Helper::Context, Helper::Locking, Helper::Logging,
          Helper::Metrics, Helper::Runner, Helper::With

        register :service, :enqueue_job

        MSGS = {
          queueing: 'enqueueing job %s (%s)',
          redirect: 'Found job.queue: %s. Redirecting to: %s'
        }

        def run
          transaction do
            info MSGS[:queueing] % [job.id, repo.slug]
            set_queued
            notify
          end
        end

        private

          def set_queued
            job.update_attributes!(state: :queued, queued_at: Time.now.utc)
          end

          def notify
            async :notify, job: { id: job.id }, meta: meta, jid: jid
          end

          def repo
            job.repository
          end

          def meta
            { state_update_count: counter.count }
          end

          def counter
            @counter ||= Model::UpdateCount.new(job, redis)
          end

          def jid
            opts[:jid]
          end

          def src
            opts[:src]
          end

          def transaction(&block)
            ActiveRecord::Base.transaction(&block)
          end
      end
    end
  end
end
