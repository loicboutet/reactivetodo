# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      define_state filter: :all
      define_state :new_todo

      before_mount do
        new_todo! TodoItem.new
      end

      def clear_completed
        TodoItem.completed = nil
        ReactiveRecord.load do # returns a promise that will resolve when all items have been loaded
          TodoItem.completed.all
        end.then do |items| # the last item loaded is returned from the promise
          items.each { |item| item.destroy }
          filter! filter == :uncompleted ? :uncompleted : :all
        end
      end

      def filtered_todos
        TodoItem.all.select { |todo| !(todo.destroyed? or (filter == :completed and !todo.complete) or (filter == :uncompleted and todo.complete))}
      end

      def add_new_todo
        new_todo.save do
          new_todo! TodoItem.new
          TodoItem.all = nil;
          filter! filter == :uncompleted ? :uncompleted : :all
        end
      end

      def selected?(which)
        "selected" if which == filter
      end

      def render

        section(id: "todoapp") do
          header(id: "header") do
            h1 do
              "Todo"
            end
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
            ul(id: "filters") do
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
      required_param :todo, type: TodoItem
      def render
        li(class: (todo.complete ? "completed" : ""), key: "todo-item-#{todo.id}") do
          div.view(class: "view")do
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
