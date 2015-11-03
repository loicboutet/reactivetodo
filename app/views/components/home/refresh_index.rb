module Components
  module Home
    class Index

      # this is one aspect of reactive-record that needs work... i.e. reloading remote values
      # we would like a way to do something like TodoItem.reload! that will reload all values and scopes currently
      # in the rendered view.

      # for now we have to do some work...

      after_mount do
        every(10) do
          TodoItem.all = nil       # clear the scope
          ReactiveRecord.load do   # .load will return a promise that resolves when all the data referenced is loaded
            TodoItem.all.each { |todo| todo.complete }  # load the completed values of all todo items
          end.then do |todos|      # load returns the last expression when the promise resolves
            todos.each { |todo| todo.complete! }  # notify react of any changes
          end
        end
      end
    end
  end

end
