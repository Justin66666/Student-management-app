# README
# CSE Grader Management System

## Functionality

1. **Student functionality**
    - Students can log in.
    - Students can browse the course catalog.
    - Students can view detailed course information, including available sections.
    - Students can apply to be graders for specific course sections.
    - Students can update their submitted application after applying.

2. **Instructor functionality**
    - Instructors can log in.
    - Instructors can browse the course catalog.
    - Instructors can submit recommendations for students to be hired as graders, even if the student has not yet logged in.

3. **Admin functionality**
    - Admins can browse the course catalog.
    - Admins can edit the course catalog (add/delete/change).
    - Admins can reload the course catalog using external OSU API data.
    - Admins can approve Instructor or Admin account requests.
    - Admins can view submitted student applications and recommendations.
    - Admins can view course sections and assign graders if needed.

4. **Authentication**
    - Devise gem is used for handling user authentication, allowing easy login, logout, and password management.
    - The application supports multiple user roles: Student, Instructor, and Admin. Each role has different access levels.

5. **External Data Integration**
    - Course and section data are dynamically pulled from the OSU Classes API (`https://contenttest.osu.edu/v2/classes/search`).
    - Admins can choose the semester and campus when reloading courses to match available offerings for the term.
    - Section data (times, locations, instructors) is updated each semester through API reloads.

6. **Application Management**
    - Students can apply to be graders and select the courses/sections they are available for.
    - Students can indicate availability for lab-based sections that require specific times.
    - Students can edit/update their applications after submission if their schedule changes.

7. **Recommendation Management**
    - Instructors can submit a recommendation for a student.
    - Recommendations are visible to admins to assist in hiring decisions.
    - Instructors can recommend students even before they create an account.

8. **Sorting, Filtering, and Searching**
    - The course catalog allows searching by course number or title.
    - Courses can be filtered by course level (1000, 2000, 3000, 4000, 5000).
    - Courses can be sorted by course number or title (ascending/descending).

9. **Frontend Styling**
    - Bootstrap 5 is used for styling across all views (tables, buttons, dropdowns).
    - Pagination is handled using the Pagy gem for better course listing navigation.

10. **Error Handling**
    - Errors during login, form submission, and course reloads are handled gracefully.
    - Foreign key constraints ensure database integrity between applications and courses.

--

## Deployment Instructions
- ALL gems need to be installed, so run `bundle install`.
- Database setup:
  - Run `rails db:create` to create the database.
  - Run `rails db:migrate` to migrate the database schema.
  - Run `rails db:seed` to populate initial admin, instructor, and student accounts.

- To start the application, run `rails server`.

--

## System Dependencies
- **Ruby** (version 3.0.0 or higher)
- **Rails** (version 8.0.0 or higher)

--

## How to Run the Test Suite
- To run the built-in Rails test suite, run `rails test`.
- If using RSpec for testing, run `bundle exec rspec`.

--

## Default Accounts
After running `rails db:seed`, the following default users are created:

- Admin: `admin.1@osu.edu`
- Instructor: `instructor.1@osu.edu`
- Student: `student.1@osu.edu`

Password for all accounts: `password123`

When you start the application, log in as the **Admin** (`admin.1@osu.edu`) first.  
Use the **Reload Courses** functionality from the admin dashboard to load course and section data for the selected semester and campus.

--

## Notes
- All required features for Projects 2 & 3 are fully implemented.
- Section/course data updates each semester via external OSU API reloads.
- Recommendation submissions by instructors are supported.
- Students can apply for and edit grader applications after submission.

## Known Issues
- Occasionally, Bootstrap styling may temporarily disappear after interacting with dropdowns (e.g., sorting the course catalog). This is caused by a Rails/Turbo rendering conflict, not a coding error.
