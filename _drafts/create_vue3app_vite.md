# How to create a Vue 3 Vite application

## Create the template

Using npm 7+, run the following command at a terminal:

```
npm init vite@latest my-vue-app -- --template vue
```

Then 

```
cd <app>
npm install
npm run dev   # to start the development server
```

Edit vite.config.js to use `@` as alias for `src` folder. The file should look like this:

```
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
// new lines from here
  resolve: {                                     
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
// to here
  }
})
```

The app logic will reside in a single file component named `\src\App.vue`. This component will be mounted inside a `div` tag with id `app` in the file `index.html`.

## Install Vue-Router

For most Single Page Applications, it's recommended to use the officially-supported vue-router library. Add it to the project:

```
npm install vue-router@4
```

Edit  `src\main.js` file and 1) import vue-rotuer library,  and 2) attach vue-router library to the app

```
import { createApp } from 'vue'
import App from '@/components/App.vue'

import router from '@/router' // 👈 1

let app = createApp(App)
app.use(router) // 👈 2
app.mount('#app')
```

Create a directory and file for the routes

```
mkdir src/router
touch src/router/index.js
```

What are views?

Create a directory for the views
```
mkdir src/views
```

Edit `src/router/index.js` and import functions form the library, import components to be used in the routes, define routes, create router function for the application, and export router function.

```
// 1. import function form library
import { createRouter, createWebHistory } from 'vue-router'

// 2. import components that will be 
import Home from '@/views/Home.vue'
import Statistics from '@/views/Statistics.vue'
import Generic from '@/views/Generic.vue'

// 3. Define rotues
const routes= [
  {path: '/', name: 'Home', component: Home},
  {path: '/statistics', name: 'Statistics', component: Statistics},
  {path: '/group/:group', name: 'Group', component: Generic, props: true}
]

// 4. Create router function for the application
const router = createRouter(
  {
    history: createWebHistory(),
    routes
  }
)

// 5. Export router function
export default router
```

## Install Vuex

Install library by running this command

```
npm install vuex@next
```

Edit `src/main.js` to 1) import the vuex-store library and  2) attach it to the app.

```
import { createApp } from 'vue'
import App from '@/components/App.vue'

import router from '@/router'
import store from '@/store' // 👈 1

let app = createApp(App)
app.use(router)
app.use(store) // 👈 2
app.mount('#app')
```

Create a directory for vuex-store and a file to manage data.

```
mkdir src/store
touch src/store/index.js
```

Edit `src/store/index.js` to import function from library, import data, create store, and export store. The store should have states properties,  and may have `getters`, `muttations` and `actions` methods.

A getter is a function to add store states into the app. Getters are functions that return a state, or states that have been operated on or combined with other values. If we want a method as a getter, we can return a function in our getter.

A mutation is just a method to modify a state.

```
\\ 1. Import functions from library
import { createStore } from 'vuex'
\\ 2. Import some sample data form json file
import data from './data.json'

// 3. Create store
const store = createStore({
  state: {
      data: data,
  },
  getters: {
    searchGroup (state) {
      return group => state.data.filter(item => item.group === group)
    }
  },
  mutations: {

  }
})

// 4.
export default store
```

In some cases where we might need to pass more than one data property to update our Vuex state, we can take advantage of object style commits. It also helps to make our commits more descriptive.

Mutations do have some limitations. Mutation methods must be synchronous so that their order of execution can be tracked with Vuex. However, Vuex has action methods that let us run mutations to modify a state.

Actions can run any kind of code, including async ones.

```
const store = new Vuex.Store({
  state: {
    answer: ""
  },
  mutations: {
    setAnswer(state, answer) {
      state.answer = answer;
    }
  },
  actions: {
    async getAnswer(context) {
    const res = await fetch("https://yesno.wtf/api");
    const answer = await res.json();
    context.commit("setAnswer", answer);
    }
  }
});
```

## Install Axios and VueAxios

```
npm install --save axios vue-axios
```

Edit `\src\main.js` file to 1) Import axios and vue-axios libraries and 2) attach  to the app.

```
import { createApp } from 'vue'
import App from '@/components/App.vue'

import router from '@/router'
import store from '@/store'
import axios from 'axios'  // 👈 1
import VueAxios from 'vue-axios'  // 👈 1

import App from '@/components/App.vue'

const app = createApp(App)
app.use(router)
app.use(store)
app.use(VueAxios, axios)  // 👈 2
app.mount('#app')
```

Edit `/src/store/index.js` to 

```
import axios from 'axios'
import Vuex from 'vuex'
import Vue from 'vue'

//load Vuex
Vue.use(Vuex);

//to handle state
const state = {
    posts: []
}

//to handle state
const getters = {
    
}

//to handle actions
const actions = {
    getPosts({ commit }) {
        axios.get('https://jsonplaceholder.typicode.com/posts')
            .then(response => {
            commit('SET_POSTS', response.data)
        })
    }
}

//to handle mutations
const mutations = {
    SET_POSTS(state, posts) {
        state.posts = posts
    }
}

//export store module
export default new Vuex.Store({
    state,
    getters,
    actions,
    mutations
})
```

## Install Bootstrap

```
npm install bootstrap --save
```

```
import { createApp } from 'vue'
import App from '@/components/App.vue'

import router from '@/router'
import store from '@/store'
import axios from 'axios'
import VueAxios from 'vue-axios'
import 'bootstrap/dist/css/bootstrap.min.css'  // 👈
import 'bootstrap/dist/js/bootstrap.bundle.min.js'  // 👈

import App from '@/components/App.vue'

const app = createApp(App)
app.use(router)
app.use(store)
app.use(VueAxios, axios)
app.mount('#app')
```

Now we can use styles and functions of javascript in any html file or template of the app.