# frozen_string_literal: true

class StatementMailer < ApplicationMailer
  def notify_email(statement)
    builder = StatementPDFService.new(statement)
    attachments[builder.filename] = builder.generate_pdf
    mail(
      to: statement.employee.email,
      bcc: ["core@5xruby.tw"],
      subject: builder.email_subject
    )
  end
end
