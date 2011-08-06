module CheckinHelper
  def checkin_link event
    link_to checkin_path(event)
  end
end
