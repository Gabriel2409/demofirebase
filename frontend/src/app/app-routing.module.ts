import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { SigninComponent } from './signin/signin.component';
import { LandingComponent } from './landing/landing.component';
import { RequireAuthComponent } from './require-auth/require-auth.component';
import { authGuard } from './auth.guard';

const routes: Routes = [
  { path: '', component: LandingComponent },
  { path: 'signin', component: SigninComponent },
  {
    path: 'require-auth',
    component: RequireAuthComponent,
    canActivate: [authGuard],
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
