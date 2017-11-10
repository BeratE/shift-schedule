get '/schedules', to: 'schedules#index'
get '/schedules/sel_pr', to: 'schedules#sel_pr'

get '/schedules/view', to: 'schedules#view'
post '/schedules/view', to: 'schedules#view'

get '/schedules/new', to: 'schedules#new'
post '/schedules/edit', to: 'schedules#edit'
post '/schedules/create', to: 'schedules#create'
post '/schedules/delete', to: 'schedules#delete'
