<script lang="ts">
	import { createClient, SupabaseClient } from '@supabase/supabase-js'
	import { onMount } from 'svelte'
	const VITE_SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
	const VITE_SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY
	const supabase: SupabaseClient = createClient(VITE_SUPABASE_URL, VITE_SUPABASE_KEY)

	let new_password = ''
	let errorMessage = ''
	let token = ''
	let active = false

	export const updatePassword = async () => {
		const { error, data } = await supabase.auth.updateUser({ password: new_password })
		if (!error) {
			active = false
		}
		return { error, data }
	}

	onMount(() => {
		checkHash()
	})

	const checkHash = () => {
		const hash = window.location.hash
		console.log('hash', hash)
		if (hash && hash.substring(0, 1) === '#') {
			const tokens = hash.substring(1).split('&')
			const entryPayload: any = {}
			tokens.map((token) => {
				const pair = (token + '=').split('=')
				entryPayload[pair[0]] = pair[1]
			})
			console.log('entryPayload', entryPayload)
			if (entryPayload?.type === 'recovery') {
				token = entryPayload.access_token
				setTimeout(() => {
					active = true
				}, 1000)
			} else if (entryPayload?.error_description) {
				// decode the error description
				const decode = (str: string) => {
					return decodeURIComponent(str.replace(/\+/g, ' '))
				}
				console.log('error_description', decode(entryPayload.error_description))
			}
		}
	}
</script>

{#if active}
	<form style="display: flex; flex-direction: column; max-width: 300px; margin: 0 auto; padding: 10px; border: 1px solid; background-color: lightgray;">
		<label for="password">Enter New Password:</label>
		<input type="password" id="password" bind:value={new_password} />
		<button on:click={updatePassword} style="align-self: center;padding: 8px;margin: 8px;">Update Password</button>
	</form>
{/if}

{#if errorMessage}
	<p style="color: red; text-align: center;">{errorMessage}</p>
{/if}
