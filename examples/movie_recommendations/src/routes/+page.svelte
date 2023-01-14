<script lang="ts">
	import Login from './Login.svelte'
	import ResetPassword from './ResetPassword.svelte';
	import { user }from './user';
	import { createClient, SupabaseClient } from '@supabase/supabase-js'
	import { onMount } from 'svelte'
	const VITE_SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
	const VITE_SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY
	const supabase: SupabaseClient = createClient(VITE_SUPABASE_URL, VITE_SUPABASE_KEY)

	let errorMessage = ''
	let favorites = ''
	let recommendations: string = ''
	$: $user && loadData()

	const updateRecommendations = async () => {
		const favoritesArray = (favorites+'\n').split('\n');
		if (favoritesArray.length === 0) {
			errorMessage = 'at least one favorite movie is required'
			return
		}
		for (let x = favoritesArray.length-1; x >= 0; x--) {
			favoritesArray[x] = favoritesArray[x].trim()
			if (favoritesArray[x].length === 0) favoritesArray.splice(x, 1);
		}
		errorMessage = 'saving favorite movies...'
		const { error: saveFavoritesError } = 
			await supabase.from('movies').upsert({
				userid: $user.id,
				favorites: favoritesArray
			})
		if (saveFavoritesError) { 
			console.error('saveFavoriteMovies error', saveFavoritesError);
			errorMessage = saveFavoritesError.message
			return
		} 
		errorMessage = 'getting recommendations...'
		const { data, error } = await supabase.rpc('movie_recommendations')
		if (error) {
			errorMessage = error.message
		} else {
			// console.log('data', data)
			recommendations = (data as any).result || '';
			errorMessage = ''
		}
	}
	const loadData = async () => {
		const { data, error } = await supabase.from('movies').select('*')
		if (error) {
			console.error('loadData', error)
			errorMessage = error.message
		} else {
			favorites = data[0]?.favorites?.join('\n') || ''
			recommendations = data[0]?.recommendations! || ''
		}
	}
	onMount(async () => {
		const { data, error} = await supabase.rpc('get_session_user');
		console.log('get_session_user', data, error)
		setTimeout(async () => {
			const { data, error} = await supabase.rpc('get_session_user');
			console.log('get_session_user', data, error)
		},2000)
	})
</script>

<h1 style="text-align: center;">Movie Recommendations</h1>

<Login />
<ResetPassword />

{#if errorMessage}
  <p style="color: red; text-align: center;">{errorMessage}</p>
{/if}

{#if $user}
  <div style="display: flex; flex-direction: column; max-width: 600px; margin: 20px auto;">
    <label for="favorites">My favorite movies (one movie per line):</label>
    <textarea rows="15" cols="60" id="favorites" bind:value={favorites}></textarea>
    <button on:click={updateRecommendations} style="align-self: center;padding: 8px;margin: 8px;">Get Movie Recommendations</button>
    <label for="recommendations">Recommendations:</label>
    <textarea disabled={true} rows="15" cols="60" id="recommendations" bind:value={recommendations}></textarea>
  </div>
{/if}
