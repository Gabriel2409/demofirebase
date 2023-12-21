import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { AngularFireModule } from '@angular/fire/compat';
import { AngularFireAuthModule } from '@angular/fire/compat/auth';
import { environment } from '../environments/environment';
import { SigninComponent } from './signin/signin.component';
import { LandingComponent } from './landing/landing.component';
import { GoogleSsoDirective } from './google-sso.directive';
import { RequireAuthComponent } from './require-auth/require-auth.component';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { bearerTokenInterceptor } from './bearer-token.interceptor';

@NgModule({
  declarations: [
    AppComponent,
    SigninComponent,
    LandingComponent,
    GoogleSsoDirective,
    RequireAuthComponent,
  ],
  imports: [
    AngularFireAuthModule,
    AngularFireModule.initializeApp(environment.firebaseConfig),
    BrowserModule,
    AppRoutingModule,
  ],
  providers: [provideHttpClient(withInterceptors([bearerTokenInterceptor]))],
  bootstrap: [AppComponent],
})
export class AppModule {}
