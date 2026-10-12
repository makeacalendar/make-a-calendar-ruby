# Payroll schedules

`Scheduling.pay_dates` supports weekly and biweekly anchors plus semi-monthly and monthly schedules. Semi-monthly defaults to the 15th and the month's last day. Monthly schedules use the anchor's day and clamp to the last day in shorter months.

Choose a non-working-day adjustment explicitly: `:none`, `:following`, `:preceding`, or `:modified_following`. Pass weekend dates and holiday dates as appropriate to the organization. No adjustment should be assumed to match every payroll contract.
