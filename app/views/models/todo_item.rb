class TodoItem < ActiveRecord::Base

  scope :completed, -> { where(complete: true)}
  scope :uncompleted, -> { where(complete: false)}
  scope :clear_completed, -> {destroy_all(complete: true); all}

end
