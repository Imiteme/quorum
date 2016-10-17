module Quorum
  class JobFetchData

    include ActiveModel::Validations

    validates_presence_of :algo, :blast_dbs, :hit_id, :hit_display_id

  end
end
