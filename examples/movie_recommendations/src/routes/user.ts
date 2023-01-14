import { writable } from 'svelte/store';

import type { User } from '@supabase/supabase-js';
export let user: any = writable<User | null>(null);
