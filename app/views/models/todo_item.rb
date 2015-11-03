class TodoItem < ActiveRecord::Base

  scope :completed, -> { where(complete: true)}
  scope :uncompleted, -> { where(complete: false)}

  #  This will not work as expected for a couple of reasons
  #     scope :clear_completed, -> {destroy_all(complete: true); all}
  #  1) everything is lazy loaded so unless at some point you did a clear_completed.count or .each
  #     there is no reason to load the scope so it never gets executed
  #  2) order is not guaranteed, so it could be that you refresh the scopes BEFORE you do the call to uncompleted
  #  3) reactive-record depends on certain semantics of scope as hints to what is going on, so no guarantee that
  #     this won't interfere with internal workings

  # The feature you need (not implemented) is an aggregate method (i.e. a method that acts on a scope, but returns a
  # single value of some time.  That is definitely on the work list!

end
