defmodule Core.Email.SaasyTemplates do
  use Core.ContextClient
  alias Core.Model.UserCode
  import Core.Email.Templates

  def password_reset(%UserEmail{address: eaddr}, [
        %UserEmail{address: reqaddr},
        %UserCode{code: code}
      ]) do
    cfg = getcfg()
    encoded = Regex.replace(~r/\s+/, eaddr, "+")

    gen_html_email(eaddr, "#{cfg.org} Password Reset", """
    <p/>
    We recently received a request to a password on an email associated with your account (#{
      reqaddr
    }).
    If you initiated this request, you can reset your password with this one-time-use code by clicking
    the Reset Password link:
    <p/>
    <a href="#{cfg.link_front}/#/pwreset?code=#{code}&email=#{eaddr}">Reset Password</a>
    <p/>
    If you are unable to view or click the link in this message, copy the following URL and paste it in your browser:
    <p/><code>#{cfg.link_front}/#/pwreset?code=#{code}&email=#{encoded}</code>
    <p/>
    This reset code will expire in 1 hour.
    <p/>
    If you did not request this change, you can ignore this email and your password will not be changed.
    <p/>
    #{cfg.support}
    <p/>
    #{cfg.email_sig}
    """)
  end

  def failed_change(%UserEmail{address: eaddr}, what) do
    cfg = getcfg()

    gen_html_email(eaddr, "#{cfg.org} Account Change Failed", """
    <p/>
    We recently received a request to #{what}, but it was unsuccessful.
    <p/>
    If you did not request this change, you can ignore this email and nothing will change.
    <p/>
    #{cfg.email_sig}
    """)
  end

  def verification(%UserEmail{address: eaddr}, %UserCode{code: code}) do
    cfg = getcfg()

    gen_html_email(eaddr, "#{cfg.org} email verification", """
    <p/>
    This email was added to an account at #{cfg.org}.  However, it is not yet verified.  Please verify this email address by clicking the Verify link:
    <p/>
    <a href="#{cfg.link_back}/ev?code=#{code}">Verify</a>
    <p/>
    If you are unable to view or click the link in this message, copy the following URL and paste it in your browser:
    <p/><code>#{cfg.link_back}/ev?code=#{code}</code>
    <p/>
    This verification code will expire in 1 day.
    <p/>
    #{cfg.support}
    <p/>
    #{cfg.email_sig}
    """)
  end

  def password_changed(%UserEmail{address: eaddr}, _) do
    cfg = getcfg()

    gen_html_email(eaddr, "#{cfg.org} email notification - password changed", """
    <p/>
    The account at #{cfg.org} associated with this email had its password changed.
    <p/>
    #{cfg.support}
    <p/>
    #{cfg.email_sig}
    """)
  end
end
