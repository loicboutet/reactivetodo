# views/components/home/index.rb
module Components
  module Home
    class Index

      include React::Component

      def render
        div do
          TodoItem.all.each do |todo|
            div do
              todo.complete.span; todo.title.span
            end
          end
        end
      end

    end

  end

end
