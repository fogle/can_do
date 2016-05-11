Can Do
======

Can Do is a DSL-based permission rules for Rails.

Example
-------

```ruby
class Permission
  def self.define_rules
    CanDo.setup do
      can :index, User do
        rule("You must be logged in.") {User.current}
        rule("You must have an active account to do this.") {User.current.active?}
      end

      can :show, User do
        cascade :index          #inherit the logged in and active rules from :index
        rule("You may not view others' accounts if they are private.") do |user|
          !user.private? || user == User.current || User.current.admin?
        end
      end

      can :update, User do
        cascade :index          #inherit the logged in and active rules from :index
        rule("You may not update others' accounts.") {|user| user == User.current || User.current.admin?}
      end

      can :delete, User do
        cascade :update
      end

      can :create, UserInterest do
        # You may create an interest if you have permission to update that user.
        cascade :update, {|interest| interest.user}
      end
    end
  end
end
```

```ruby
# application.rb
ActionDispatch::Callbacks.to_prepare do
  Permission.define_rules       #allows rules to be reloaded when classes are reloaded
end
```

```ruby
# users_controller.rb
def index
  require_permission! :index, User  #this will raise a CanDo::PermissionError if permission is denied
  ...
end

def show
  @user = User.find(params[:id])
  require_permission! :show, user   #this will raise a CanDo::PermissionError if permission is denied
  ...
end
```


```ruby
# application_controller.rb
rescue_from CanDo::PermissionError do |error|
  render :text => "Permission denied: #{error.message}"
end

before_filter :initialize_current_user

def initialize_current_user
  User.current = your_code_goes_here
end
```

```ruby
# user.rb
def self.current=(value)
  Thread.current["User.current"] = value
end

def self.current
  Thread.current["User.current"]
end
```

```haml
/ users/index.haml
%ul
  - @users.each do |user|
    - can?(:show, user) do
      %li
        = link_to user.name, user_path(user)
        - if can?(:update, user) do
          = link_to "Edit", edit_user_path(user)
- can?(:create, User) do
  = link_to "Add User", new_user_path
```

Testing
-------

To test your permission logic, simply call `CanDo.reason(:verb, object)` and test that the reason is what you expect. Make sure to test all rules inherited from cascades as well. Without this, it's easy for cascades to introduce unintended consequences.

Comparison
----------

Special thanks to [cancan][], upon which Can Do is loosely based. Important differences:

- For large permission sets, cancan slows down dramatically. Can Do uses hash-based lookups, which dramatically reduces performance overhead.
- Can Do is far more expressive, allowing user-friendly explanations for failures.
- Can Do has explicit support for cascading rules to reduce repetition.

[cancan]: https://github.com/ryanb/cancan
