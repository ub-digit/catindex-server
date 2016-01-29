class V1::V1Controller < ApplicationController
  before_filter :validate_access
  before_filter -> { validate_rights 'oper' }
end
