# Shift Schedule
Shift Schedule is a Redmine plug-in for managing the weekly budget of the developers onto different versions of projects.

## Installation
- Clone the repository into: /#{REDMINE_ROOT}/plugins/.
- Rename the directory 'shift-schedule' to 'shift_schedule'.
- Run the migration: bundle exec rake redmine:plugins:migrate NAME=shift_schedule RAILS_ENV=production.
- Hint: Check if your /#{REDMINE_ROOT}/public/plugin_assets/shift_schedule directory is installed correctly.
Try: bundle exec rake redmine:plugins:assets. If this fails, copy the javascript and stylesheet files manually.

## Use
Use of this plug-in is pretty straight forward

- Administrators can set a global time buffer in percent, which will be subtracted from all shift hours.
- Users can configure their weekly shift hours (budget) on their account page.
- Following rights can be assigned to roles:
..* View schedules:
User may view the assigned schedules and navigate through the weeks.
..* Edit schedules:
Users may see the schedules, navigate through the weeks, edit and save the scheduled hours,
add versions to the week and delete scheduled versions (with all the corresponding schedules hours).
- On the top-bar navigation the 'Schedule' link will lead to the project selection page or the schedule page (for the current week),
if a project has already been selected.
- In the project selection page, users can select a project in which they are involved in and have rights assigned to.
- After choosing a project, the corresponding project links are displayed at the top with the schedule for the current week.
- All users that are assigned to the project, have rights to the schedule and have a budget configured will be listed.
- On the schedule page, the weeks can be navigated through a calender
- Clicking on the '+Version' button will lead to a listing of all versions of the project not scheduled for the selected week.
Clicking on a version will add that version to the selected week for scheduling.
- Hours of assigned users can be freely edited, a click on the 'save' button will save the edited hours.
- Clicking on the '-' next to the version names will delete that version from the week (including all the corresponding scheduled hours).
- The 'User Overview' Tab lists a table of all assigned schedules for the selected year over all users assigned to the correspond project.

## Notes
- Mind that only members with set shift hours are listed in the scheduling view. The default for unset shift hours is NULL.

## License
The application is published under the [GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.html).
