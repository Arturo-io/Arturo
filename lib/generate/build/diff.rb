module Generate
  module Build 
    class Diff < Generic
      attr_reader :build_id

      def initialize(build_id)
        @build_id = build_id
      end
    end
  end
end
