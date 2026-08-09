Implementation Plan

I’d implement this as a location hierarchy, not just “add countries to the contact page.” The clean model should become:
Country -> States/Regions -> Zones -> Areas

For Nigeria, “States” remain Abia, Delta, Lagos, etc. For Ghana/US/UK, the same table can represent regions/states/counties depending on the country.

1. Add Countries To The CMS
Create a new Country model with fields like:
name, code, slug, status, description, contact_info, phone, email, address, sort_order

Then update State so it belongs to a country:
Country has_many :states
State belongs_to :country
There is already a legacy states.country string column, so I’d migrate existing records by creating/finding Nigeria, then assigning all current states to that country. After migration, the app should use country_id, not the old string.

2. Scope Zones By Country
Right now Zone has_many :states, but zones are implicitly Nigerian. 

I’d update:
Country has_many :zones
Zone belongs_to :country
Zone has_many :states

This allows Nigeria to have its zones, Ghana to have its own zones, and the US/UK to use whatever structure TOM prefers.

3. Keep Areas Under States/Regions
The current Area belongs_to :state is still fine. That gives:
Ghana -> Greater Accra -> Accra Zone -> Adenta Area
or
US -> Texas -> South Zone -> Houston Area

If TOM later needs another level, like Districts or Chapters below Areas, that can be added later. I would not add that now unless it is already operationally needed.

4. Update Admin CMS
Add admin screens:
Admin > Countries
Admin > Countries > States/Regions
Admin > Countries > Zones

Then adjust the existing State form:
Add country selector.

Rename UI copy from “State” to “State / Region” where appropriate.
Filter zone dropdown by country, or at minimum show zone labels grouped by country.
Update admin state list to group/filter by country.

The sidebar should probably become “Countries & Chapters” instead of only “States.”

5. Replace Hard-Coded Camp States
The current camp modal uses Event::CAMP_STATE_NAMES, a hard-coded Nigeria list. That is the biggest limitation.

I’d replace it with active CMS locations:
Load active countries.
Load active states/regions per country.
Render country sections or country tabs.
Under each country, render the states/regions.
Keep the existing modal behavior for details.
For camp details, I’d add a real reference:
camp_details.state_id
and keep state_name temporarily for backward compatibility during migration.

6. Contact Page Update
The contact page should load all active countries and their active states/regions, with contact details from the CMS.

Recommended UI:
Heading: Choose Your Location
Country tabs: Nigeria, Ghana, United States, United Kingdom, etc.
Inside each country tab: grid of states/regions.
Clicking a state/region opens the existing modal style with:country name
state/region name
zone
areas
contact person/details
address
phone/email
map image if available
notes/description

If a country has direct national contact info but no states yet, show a country card/modal too.

7. Data Migration
Migration steps:
Create countries.
Create Nigeria country.
Assign all existing states to Nigeria.
Add country_id to zones and assign existing zones to Nigeria.
Add indexes and uniqueness:country code unique
state code unique per country
state name unique per country
zone name unique per country

Later, remove or ignore legacy states.country.

8. Tests To Add
I’d add tests for:
Creating countries in admin.
Creating states/regions under different countries with same names allowed only when country differs.
Contact page renders country tabs and state/region buttons.
Contact modal payload includes country/state/area details.
Camp editor no longer depends on hard-coded Nigerian states.

Existing Nigeria event camp behavior still works.

Recommended Build Order
- Database + models: Country, country_id on states/zones.
- Admin country CRUD.
- Update state/zone admin forms and validations.
- Update camp details to use CMS states instead of Event::CAMP_STATE_NAMES.
- Update contact page with country/state modal UI.
- Backward compatibility cleanup and tests.

That’s the path I’d take. It preserves your current Nigeria data, supports Ghana/US/UK cleanly, and avoids painting the ministry into another country-specific corner later.

#W@ff!3mttAdmin



