module PayPeriodsHelper
  def mark_paid_button(pay_period)
    if pay_period.paid?
      content_tag("div", "Paid", :class => "paid")
    else
      button_to("Mark as paid", mark_paid_admin_pay_period_path(pay_period))
    end
  end
end
