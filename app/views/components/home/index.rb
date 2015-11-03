# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      define_state filter: :all     # a state is like an instance variable that notifies react when it changes

      def filtered_todos            # return the current filtered todos
        TodoItem.all.select { |todo| !(todo.destroyed? or (filter == :completed and !todo.complete) or (filter == :uncompleted and todo.complete))}
      end

      def selected?(which)          # returns the selected class if 'which' is the current filter
        "selected" if which == filter
      end

      define_state :new_todo        # new_todo will always hold a new todo to be inserted

      before_mount do               # before mount is very much like the initialize method
        new_todo! TodoItem.new      # state variables are updated using the bang method.  sets the variables, AND notifies react
      end

      def add_new_todo
        new_todo.save do           # the block is executed when the save completes
          new_todo! TodoItem.new
          TodoItem.all = nil       # clearing the scope will force it to be refetched from the server (this is a current shortfall in reactive-record)
          filter! filter == :uncompleted ? :uncompleted : :all  # even if filter is not changing we would like to notify react so it rerenders the list
        end
      end

      def clear_completed
        TodoItem.completed = nil    # clear the local copy of the scope so we will refetch it
        ReactiveRecord.load do      # returns a promise that will resolve when all items have been loaded
          TodoItem.completed.all
        end.then do |items|         # the last item loaded is returned from the promise
          items.each { |item| item.destroy }
          filter! filter == :uncompleted ? :uncompleted : :all
        end
      end

      def render

        section(id: "todoapp") do  # all html tags have ruby methods which will add the tag to the render buffer
          header(id: "header") do  # tag attributes are passed as the parameter hash, and the block receives the tag body
            h1 do
              "Todo"
            end
            # application defined tags are invoked by using the class name
            # the text field component will update the field value of he passed record, and notify us if the enter key is pressed
            TextField record: new_todo, field_name: :title, on_enter: -> { add_new_todo }, html_options: {id: "new-todo", placeholder: "What's left to do ? "}
          end
          section(id: "main", style: {display: "block"}) do
            ul(id: "todo-list") do
              filtered_todos.each do |todo|
                Todo todo: todo
              end
            end
          end
          footer(id: "footer", style: {display: "block"}) do
            span(id: "todo-count") do
              "#{filtered_todos.count} #{filter+' ' unless filter == :all} item#{'s' if filtered_todos.count > 1} left"
            end
            ul(id: "filters") do   # event handlers are attached using the .on method which may be chained for multiple event types
              li { a(class: selected?(:all)) { "All" }.on(:click) { filter! :all }}
              li { a(class: selected?(:completed)) { "Completed" }.on(:click) { filter! :completed }}
              li { a(class: selected?(:uncompleted)) { "Active" }.on(:click) { filter! :uncompleted }}
            end
            button(id: "clear-completed") { "clear completed" }.on(:click) { clear_completed }
          end
        end
      end

    end

    class Todo

      include React::Component

      required_param :todo, type: TodoItem   # parameters may be required or optional, and may be type checked

      def render
        # react tries hard not re-render things.  The 'key' help react keep things straight as list items are added and removed
        li(class: (todo.complete ? "completed" : ""), key: "todo-item-#{todo.id}") do
          div.view do                        # classes may be 'sent' to the tag as method names 'haml' style
            input.toggle(type: :checkbox, (todo.complete ? :checked : :unchecked) => true).on(:click) do
              todo.complete = !todo.complete
              todo.save
            end
            label do
              todo.title
            end
          end
        end
      end

    end
  end
end
