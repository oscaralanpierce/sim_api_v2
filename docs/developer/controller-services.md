# Controller Services

Controller services are a design pattern we use to keep controller logic simple and encapsulated as described in [ADR 2](/docs/adrs/0002-use-controller-services.md).

## Table of Contents

- [Class Structure](#class-structure)
  - [The `Service::ErrorResult` Class](#the-serviceerrorresult-class)
    - [The `Service::UnauthorizedResult`](#the-serviceunauthorizedresult)
  - [The `Service::SuccessResult` Class](#the-servicesuccessresult-class)
  - [The `Controller::Response` Class](#the-controllerresponse-class)
- [Adding Handlers to an Existing Controller](#adding-handlers-to-an-existing-controller)
- [Building New Controllers](#building-new-controllers)

## Class Structure

Controller services live in the `/app/controller_services/<controller_name>` directory, with one service for each route handled by the controller in question. So, for example, the `PlaythroughsController` might have the following structure:

`/app/`
  `controller/`
    `playthroughs_controller.rb`
  `controller_services/`
    `playthroughs_controller/`
      `create_service.rb`
      `destroy_service.rb`
      `index_service.rb`
      `show_service.rb`
      `update_service.rb`

Controller services are initialized with any params required for the request handling logic, which is then implemented in their `#perform` instance method. This method returns a subclass of `Service::SuccessResult` (including a resource to be returned in the response body, unless it is a `Service::NoContentResult`) or `Service::ErrorResult` (including any errors to be returned in the response body).

The handler methods within the controller (e.g., `#create`, `#update`, `#show`, `#index`, `#destroy`) instantiate the relevant service and create a `Controller::Response` object with the result returned by its `#perform` method, calling `#execute` on the response object to generate a response to the request:

```ruby
require 'controller/response'

class WidgetsController < ApplicationController
  def create
    result = CreateService.new(current_user, widget_params)

    ::Controller::Response.new(self, result).execute
  end

  private

  def widget_params
    params.require(:widget).permit(:name, :description)
  end
end
```

### The `Service::ErrorResult` Class

Subclasses of `Service::ErrorResult`, such as `Service::NotFoundResult` and `Service::UnprocessableEntityResult` take an options hash that can include an `:errors` array, an `:error` array or string, or both. These are normalised into a flattened `:errors` array that is returned in the response body. If both keys are defined, the value of `:error` is added to the final `:errors` array as well.

Each subclass defines a `#status` method. This method returns the symbol that Rails uses to indicate a particular server response. For example, `:unprocessable_entity` becomes status 422, `:not_found` becomes status 404, etc.

#### The `Service::UnauthorizedResult`

The `Service::UnauthorizedResult` class is an important element in the security of the API, and for that reason behaves a little differently from other `Service::ErrorResult` subclasses. Unauthorized results should _never_ return a resource of any kind. They should also always return the same, generic failure message. Giving a specific failure reason, or returning different error messages at different stages in program execution, risks giving an attacker data points to help formulate their next attempt. All a client needs to know about an authorization failure is that authorization has failed. More specific errors, if available, are logged so the application maintainers can further investigate authorization failures.

### The `Service::SuccessResult` Class

Subclasses of `Service::SuccessResult`, such as `Service::OkResult` and `Service::CreatedResult`, take a `resource` that will be returned in the response body, generally an Active Record model or collection. `Service::NoContentResult` instances do not have a resource defined; any resource passed into their constructor will be squashed. If you need a resource, you should not use `Service::NoContentResult`.

### The `Controller::Response` Class

The `Controller::Response` class is instantiated with a controller instance and a `Service::ErrorResult` or `Service::SuccessResult` subclass instance. Its `#execute` method renders the status and response body indicated by the result object from the controller passed in, calling either `#head` (for the `Service::NoContentResult`) or `#render` (for other result classes) on the controller.

## Adding Handlers to an Existing Controller

If you want to add a new route, you will need to add a handler to the relevant controller. In order to do this, you should create a controller service in the `/app/controller_services/<some_controller>/` directory with a class name corresponding to the handler. The class is then namespaced under the controller class, in keeping with Zeitwerk requirements. Any data required to handle the request, such as a logged-in user or request params, should be passed into your service's initializer and stored in instance variables. The instance method `#perform` returns whatever `Service::SuccessResult`/`Service::ErrorResult` subclasses it may need to handle the request (often a success class like `Service::OkResult` and one or more error classes like `Service::NotFoundResult`).

```ruby
import 'service/ok_result'
import 'service/not_found_result'
import 'service/internal_server_error_result'
import 'service/unprocessable_entity_result'

class WidgetsController < ApplicationController
  class UpdateService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def perform
      widget = Widget.find(params[:id])

      return Service::NotFoundResult.new(error: "Could not find widget #{params[:id]}") if !widget

      widget.update!(params)
      Service::OkResult.new(resource: widget)
    rescue ActiveRecord::RecordInvalid => e
      Service::UnprocessableEntityResult.new(error: e.message)
    rescue StandardError => e
      Service::InternalServerErrorResult.new(error: 'Oh no')
    end

    private

    attr_reader :user, :params
  end
end
```

## Building New Controllers

When creating a new controller, such as when you've introduced a new RESTful resource, you will need to create the controller class in `/app/controllers/` and any controller services it may use in `/app/controller_services/<your_controller>/`. There should be one service class per route handler in the controller. You can define each controller service in the manner described above.
