import { Component } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';

@Component({
  selector: 'app-signin',
  templateUrl: './signin.component.html',
  styleUrl: './signin.component.scss',
})
export class SigninComponent {
  constructor(public angularFireAuth: AngularFireAuth) {}

  logOut() {
    this.angularFireAuth.signOut();
  }
}
