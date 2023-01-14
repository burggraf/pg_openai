<script lang="ts">
	import { createClient, SupabaseClient } from '@supabase/supabase-js'
	import { onMount } from 'svelte'
	import { user } from './user'
	const VITE_SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
	const VITE_SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY
	const supabase: SupabaseClient = createClient(VITE_SUPABASE_URL, VITE_SUPABASE_KEY)

	supabase.auth.onAuthStateChange(async (event, session) => {
		user.set(session?.user ?? null)
	})

	let email = ''
	let password = ''
	let new_password = ''
	let errorMessage = ''
	let token = ''

	const signin = async () => {
		const { data, error } = await supabase.auth.signInWithPassword({
			email: email,
			password: password,
		})
		if (error?.message) {
			errorMessage = error.message
		} else {
			errorMessage = ''
		}
	}
	const signup = async () => {
		const { data, error } = await supabase.auth.signUp({
			email: email,
			password: password,
		})
		if (error) {
			errorMessage = error?.message || 'unknown error'
		} else {
			errorMessage = ''
		}
	}
	const signout = async () => {
		const { error } = await supabase.auth.signOut()
		if (error) {
			errorMessage = error?.message || 'unknown error'
		} else {
			errorMessage = ''
		}
	}
	const sendPasswordResetLink = async () => {
		const { error } = await supabase.auth.resetPasswordForEmail(email, {
			redirectTo: window.location.origin,
		})
		if (error) {
			errorMessage = error?.message || 'unknown error'
		} else {
			errorMessage = 'Check your email for a password reset link.'
		}
	}
</script>

{#if $user}
	<p style="text-align: center;">
		Signed in as {$user.email}
		<button style="padding: 8px;margin: 8px;" on:click={signout}>Sign Out</button>
	</p>
{:else}
	<form style="display: flex; flex-direction: column; max-width: 300px; margin: 0 auto;">
		<label for="email">Email:</label>
		<input type="email" id="email" bind:value={email} />
		<label for="password">Password:</label>
		<input type="password" id="password" bind:value={password} />
		<div style="display: flex; justify-content: space-between;">
			<button style="padding: 8px;margin: 8px;" on:click={signup}>Sign Up</button>
			<button style="padding: 8px;margin: 8px;" on:click={sendPasswordResetLink}>Forgot Password</button>
			<button style="padding: 8px;margin: 8px;" on:click={signin}>Sign In</button>
		</div>
	</form>
{/if}

{#if errorMessage}
	<p style="color: red; text-align: center;">{errorMessage}</p>
{/if}
