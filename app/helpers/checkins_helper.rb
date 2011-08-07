module CheckinsHelper
  def checkin_link event
    button_to checkin_path(event)
  end
end
