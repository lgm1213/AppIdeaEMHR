# frozen_string_literal: true

# ==============================================================================
# BONUS IMPROVEMENT: Enhanced ApplicationHelper
# ==============================================================================
# File: app/helpers/application_helper.rb
#
# Common helper methods for formatting and display across the application.
# ==============================================================================

module ApplicationHelper
  # ===========================================================================
  # Date & Time Formatting
  # ===========================================================================

  # Format date for display (e.g., "Jan 23, 2026")
  def format_date(date, default: "N/A")
    return default if date.blank?
    date.strftime("%b %d, %Y")
  end

  # Format date in short form (e.g., "01/23/26")
  def format_date_short(date, default: "N/A")
    return default if date.blank?
    date.strftime("%m/%d/%y")
  end

  # Format date in ISO format (e.g., "2026-01-23")
  def format_date_iso(date, default: "")
    return default if date.blank?
    date.strftime("%Y-%m-%d")
  end

  # Format time for display (e.g., "2:30 PM")
  def format_time(time, default: "N/A")
    return default if time.blank?
    time.strftime("%l:%M %p").strip
  end

  # Format datetime for display (e.g., "Jan 23, 2026 at 2:30 PM")
  def format_datetime(datetime, default: "N/A")
    return default if datetime.blank?
    datetime.strftime("%b %d, %Y at %l:%M %p").strip
  end

  # Format datetime in short form (e.g., "01/23/26 2:30 PM")
  def format_datetime_short(datetime, default: "N/A")
    return default if datetime.blank?
    datetime.strftime("%m/%d/%y %l:%M %p").strip
  end

  # Relative time (e.g., "2 hours ago", "in 3 days")
  def time_ago_or_future(time)
    return "N/A" if time.blank?

    if time > Time.current
      "in #{time_ago_in_words(time)}"
    else
      "#{time_ago_in_words(time)} ago"
    end
  end

  # ===========================================================================
  # Currency & Number Formatting
  # ===========================================================================

  # Format as currency (e.g., "$1,234.56")
  def format_currency(amount, default: "$0.00")
    return default if amount.blank?
    number_to_currency(amount)
  end

  # Format phone number (e.g., "(305) 555-1234")
  def format_phone(phone, default: "N/A")
    return default if phone.blank?

    digits = phone.to_s.gsub(/\D/, "")
    case digits.length
    when 10
      "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
    when 11
      "+#{digits[0]} (#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
    else
      phone # Return as-is if format unknown
    end
  end

  # Format NPI (e.g., "1234567890" -> "123-456-7890")
  def format_npi(npi, default: "N/A")
    return default if npi.blank?
    npi.to_s.gsub(/(\d{3})(\d{3})(\d{4})/, '\1-\2-\3')
  end

  # ===========================================================================
  # Status Badges
  # ===========================================================================

  # Generic status badge with color coding
  def status_badge(status, color: nil)
    return "" if status.blank?

    color_class = color || status_color_class(status)
    content_tag(:span, status.to_s.titleize,
                class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{color_class}")
  end

  # Determine color class based on status
  def status_color_class(status)
    case status.to_s.downcase
    when "active", "completed", "signed", "confirmed", "success"
      "bg-green-100 text-green-800"
    when "pending", "scheduled", "draft", "in_progress"
      "bg-yellow-100 text-yellow-800"
    when "inactive", "cancelled", "failed", "no_show"
      "bg-red-100 text-red-800"
    when "checked_in"
      "bg-blue-100 text-blue-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # Boolean badge (Yes/No)
  def boolean_badge(value)
    if value
      status_badge("Yes", color: "bg-green-100 text-green-800")
    else
      status_badge("No", color: "bg-gray-100 text-gray-800")
    end
  end

  # ===========================================================================
  # UI Components
  # ===========================================================================

  # Flash message styling
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-50 border-green-400 text-green-800"
    when :alert, :error
      "bg-red-50 border-red-400 text-red-800"
    when :warning
      "bg-yellow-50 border-yellow-400 text-yellow-800"
    else
      "bg-blue-50 border-blue-400 text-blue-800"
    end
  end

  # Flash icon
  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      icon_check_circle
    when :alert, :error
      icon_x_circle
    when :warning
      icon_exclamation_triangle
    else
      icon_information_circle
    end
  end

  # Active navigation link helper
  def nav_link_class(path, exact: false)
    is_active = exact ? current_page?(path) : request.path.start_with?(path)

    base = "group flex gap-x-3 rounded-md p-2 text-sm font-semibold leading-6"
    if is_active
      "#{base} bg-gray-50 text-indigo-600"
    else
      "#{base} text-gray-700 hover:bg-gray-50 hover:text-indigo-600"
    end
  end

  # Page title helper
  def page_title(title = nil)
    base = "EMHR"
    title.present? ? "#{title} | #{base}" : base
  end

  # ===========================================================================
  # Text Helpers
  # ===========================================================================

  # Truncate with tooltip
  def truncate_with_tooltip(text, length: 30)
    return "" if text.blank?
    return text if text.length <= length

    content_tag(:span, truncate(text, length: length),
                title: text,
                class: "cursor-help")
  end

  # Display value or default
  def display_or_default(value, default: "—")
    value.present? ? value : content_tag(:span, default, class: "text-gray-400")
  end

  # Pluralize with count
  def count_label(count, singular, plural = nil)
    word = count == 1 ? singular : (plural || singular.pluralize)
    "#{number_with_delimiter(count)} #{word}"
  end

  # ===========================================================================
  # Icons (Heroicons outline style)
  # ===========================================================================

  def icon_check_circle
    content_tag(:svg, class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2",
               d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z")
    end
  end

  def icon_x_circle
    content_tag(:svg, class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2",
               d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z")
    end
  end

  def icon_exclamation_triangle
    content_tag(:svg, class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2",
               d: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z")
    end
  end

  def icon_information_circle
    content_tag(:svg, class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2",
               d: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z")
    end
  end

  def icon_medical_history
    # Returns a simple SVG string (or use whatever icon library you prefer)
    raw '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>'
  end
end
