Victual
=======
-----
[![Build Status](https://secure.travis-ci.org/appsfactory/Victual.png)](https://secure.travis-ci.org/appsfactory/Victual)

Eat lunch with random people near you.


Rake tasks are scheduled to run daily
Schedule: 10:30. The first, major matcher. Sets phase to late.
                 Any user after this will trigger a matching function (add_latecomer) immediately.
toolate: 2:30. Simply changes phase to toolate. Any user after this will be marked keep.
Rdb: Midnight. Removes all users and groups, except for those marked "keep". Sets phase to "".
