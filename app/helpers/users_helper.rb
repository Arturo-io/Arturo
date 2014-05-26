module UsersHelper
  def plan_button(user_plan, plan, email)
    text    = plan_button_text(user_plan, plan.name)
    render 'stripe_button', text: text, plan: plan, email: email
  end

  def plan_button_text(user_plan, plan)
    return "Current" if current_plan?(user_plan, plan)
    return "Switch"
  end

  def current_plan?(user_plan, plan)
    user_plan.name == plan
  end

  def builds(is_priority)
    return "Priority Builds" if is_priority
    "Public Builds"
  end

  def price(string)
    return "Free" if string == "0"
    return "$#{string.to_f/100}"
  end
end
