class FurtherInformationController < ApplicationController
  def index
    @attribute = FURTHER_INFORMATION_SERVICE.fetch(cookies)
    @form = CycleThreeForm.new({})
    @transaction_name = current_transaction.name
  end

  def submit
    form = CycleThreeForm.new(params['cycle_three_form'])
    FURTHER_INFORMATION_SERVICE.submit(cookies, form.cycle_three_data)
    redirect_to response_processing_path
  end
end
