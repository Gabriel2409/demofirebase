import { Directive, HostListener } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { GoogleAuthProvider } from '@firebase/auth';

@Directive({
  selector: '[googleSso]',
})
export class GoogleSsoDirective {
  constructor(private angularFireAuth: AngularFireAuth) {}

  @HostListener('click')
  async onClick() {
    const creds = await this.angularFireAuth.signInWithPopup(
      new GoogleAuthProvider(),
    );
    // do what you want with the credentials, for ex adding them to firestore...
  }
}
