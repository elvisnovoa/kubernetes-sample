/**
 * @license
 * Copyright (c) 2016 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
 */

import { PolymerElement, html } from '@polymer/polymer/polymer-element.js';
import '@polymer/iron-ajax/iron-ajax.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-input/paper-input.js';
import '@polymer/iron-input/iron-input.js';
import '@polymer/app-route/app-location.js';
import '@polymer/app-route/app-route.js';
import '@vaadin/vaadin-grid/vaadin-grid.js';

import './shared-styles.js';

class HomePage extends PolymerElement {
  static get template() {
    return html`
      <style include="shared-styles">
        :host {
          display: block;

          padding: 10px;
        }
      </style>

      <app-location route="{{route}}"></app-location>

      <div class="card">
        <h1>Accounts</h1>
        <paper-button raised on-tap="refreshAccounts" class="primary">Refresh accounts</paper-button>
        
        <vaadin-grid id="table" items="[[accounts]]">
          <vaadin-grid-column path="name" header="Nickname"></vaadin-grid-column>
          <vaadin-grid-column path="type" header="Type"></vaadin-grid-column>
          <vaadin-grid-column path="postedBalance" text-align="end" width="60px" ></vaadin-grid-column>
          <vaadin-grid-column path="availableBalance" text-align="end" width="60px" ></vaadin-grid-column>
        </vaadin-grid>
      </div>
      
      
      <iron-ajax
        id="getAccountsAjax"
        auto
        url="http://localhost:8080/accounts"
        method="get"
        handle-as="json"
        on-response="handleUserResponse">
      </iron-ajax>
    `;
  }

  static get properties() {
    return {
      accounts: Object
    }
  }

  refreshAccounts() {
    this.$.getAccountsAjax.generateRequest();
  }

  handleUserResponse(event) {
    var response = event.detail.response;

    if (response._embedded) {
      this.accounts = response._embedded.accounts;
    }
  }
}

window.customElements.define('home-page', HomePage);

