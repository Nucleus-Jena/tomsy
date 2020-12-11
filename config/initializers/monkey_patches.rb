module ActiveResource
  module Formats
    # Disable remove_root to prevent deletion of single element key
    # Camunda::CamundaTask.find(task_id).get(:variables)
    # {"data_entity_id"=>{"type"=>"Long", "value"=>1, "valueInfo"=>{}}}
    def self.remove_root(data)
      data
    end
  end
end
