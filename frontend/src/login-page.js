/**
 * @license
 * Copyright (c) 2016 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
 */

import {PolymerElement, html} from '@polymer/polymer/polymer-element.js';
import '@polymer/iron-localstorage/iron-localstorage.js';
import '@polymer/iron-ajax/iron-ajax.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-input/paper-input.js';
import '@polymer/iron-input/iron-input.js';
import '@polymer/app-route/app-location.js';
import '@polymer/app-route/app-route.js';
import './log-out.js';

// <link rel="import" href="../bower_components/app-route/app-location.html">

import './shared-styles.js';

class LoginPage extends PolymerElement {
    static get template() {
        return html`
      <style include="shared-styles">
        :host {
          display: block;

          padding: 10px;
        }
        
        .wrapper-btns {
          margin-top: 15px;
        }
        
        paper-button.link {
          color: #757575
        }
        
        .alert-error {
          background: #ffcdd2;
          border: 1px solid #f44336;
          border-radius: 3px;
          color: #333;
          font-size: 14px;
          padding: 10px;
        }
        
        input {
            @apply --paper-input-container-shared-input-style;
        }
      </style>
      
      <iron-ajax
        id="registerLoginAjax"
        method="post"
        content-type="application/json"
        handle-as="json"
        on-response="handleUserResponse"
        on-error="handleUserError">
      </iron-ajax>
      
      <app-location route="{{route}}"></app-location>

      <iron-localstorage name="user-storage" value="{{storedUser}}"></iron-localstorage>
      
      
      <template is="dom-if" if="[[error]]">
        <p class="alert-error"><strong>Error:</strong> [[error]]</p>
      </template>

      <div class="card">
        <div id="unauthenticated" hidden$="[[storedUser.loggedin]]">
            <h1>Log In</h1>
    
        <p><strong>Log in</strong> or <strong>sign up</strong> to access your accounts</p>
    
        <paper-input-container>
          <label slot="input">Username</label>
          <iron-input slot="input" bind-value="{{formData.username}}">
            <input id="username" type="text" value="{{formData.username}}" placeholder="Username">
          </iron-input>
        </paper-input-container>
    
        <paper-input-container>
          <label>Password</label>
          <iron-input slot="input" bind-value="{{formData.password}}">
            <input id="password" type="password" value="{{formData.password}}" placeholder="Password">
          </iron-input>
        </paper-input-container>
    
        <div class="wrapper-btns">
          <paper-button raised class="primary" on-tap="postLogin">Log In</paper-button>
        </div>
      </div>
      
      <div id="authenticated" hidden$="[[!storedUser.loggedin]]">
        <h2>Hello, [[storedUser.name]]!</h2>
        <p>You are currently logged in. You can access <a href="[[rootPath]]home-page">your accounts</a></p>
        <log-out stored-user="{{storedUser}}"></log-out>

      </div>
    `;
    }

    static get properties() {
        return {
            formData: {
                type: Object,
                value: {}
            },
            storedUser: Object,
            error: String
        }
    }

    _setReqBody() {
        this.$.registerLoginAjax.body = this.formData;
    }

    postLogin() {
        this.$.registerLoginAjax.url = 'http://localhost:8080/login';
        this._setReqBody();
        this.$.registerLoginAjax.generateRequest();
    }

    handleUserResponse(event) {
        var response = event.detail.response;

        if (response.id) {
            this.error = '';
            this.storedUser = {
                name: this.formData.username,
                loggedin: true,
                firstName: response.firstName,
                lastName: response.lastName
            };
            this.set('route.path', '/home-page');

        }

        // reset form data
        this.formData = {};
    }

    handleUserError(event) {
        this.error = event.detail.request.xhr.response.error;
    }
}

window.customElements.define('register-login', LoginPage);
