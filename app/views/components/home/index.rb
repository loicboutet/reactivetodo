# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      define_state filter: :all

      def clear_completed
        TodoItem.completed = nil
        ReactiveRecord.load do # returns a promise that will resolve when all items have been loaded
          TodoItem.completed.all
        end.then do |items| # the last item loaded is returned from the promise
          items.each { |item| item.destroy }
          filter! :all unless filter == :uncompleted
        end
      end

      def filtered_todos
        TodoItem.all.select { |todo| !(todo.destroyed? or (filter == :completed and !todo.complete) or (filter == :uncompleted and todo.complete))}
      end

      def render
        section(id: "main", style: {display: "block"}) do
          div { "There are #{filtered_todos.count} #{filter+' ' unless filter == :all} todo#{'s' if filtered_todos.count > 1}" }
            ul(id: "todo-list") do
              filtered_todos.each do |todo|
                Todo todo: todo
              end
            end
          button { "completed" }.on(:click) { filter! :completed }
          button { "uncompleted" }.on(:click) { filter! :uncompleted }
          button { "all" }.on(:click) { filter! :all }
          button { "clear completed" }.on(:click) { clear_completed }
          button { "create" }.on(:click) { TodoItem.new(title: "test").save { TodoItem.all = nil; filter! :all unless filter == :uncompleted } }
        end
      end

    end

    class Todo
      include React::Component
      required_param :todo, type: TodoItem
      def render
        li(class: (todo.complete ? "completed" : "")) do
          div(class: "view")do
            input(type: :checkbox, (todo.complete ? :checked : :unchecked) => true, :class => "toggle").on(:click) do
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
