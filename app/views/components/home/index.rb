# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      define_state :todos

      before_mount do
        todos! TodoItem.all
      end

      def render
        div do
          todos.each do |todo|
            if todo.id != nil
              div do
                todo.complete.span; todo.title.span
                button { "complete" }.on(:click) { |evt| todo.complete = true; todo.save }
                button { "destroy"  }.on(:click) { |evt| todo.destroy; force_update! }
              end
            end
          end
          todos.count.span
          button { "completed" }.on(:click) { |evt| todos! TodoItem.completed}
          button { "uncompleted" }.on(:click) { |evt| todos! TodoItem.uncompleted}
          button { "all" }.on(:click) { |evt| todos! TodoItem.all}
          button { "clear completed" }.on(:click) { |evt| todos! TodoItem.clear_completed}

        end
      end

    end
  end
end
