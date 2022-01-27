module ThreadSafeDicts

using Distributed

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.haskey, Base.delete!, Base.print, Base.iterate, Base.length

export ThreadSafeDict, EnableLock, DisableLock

""" 
    ThreadSafeDict(pairs::Vector{Pair{K,V}})   
Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass 
arguments to the d member Dict, unlock the spinlock, and then return what is returned by the Dict.
"""
mutable struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
    dlock::Threads.SpinLock
    enabled::Bool
    d::Dict
    ThreadSafeDict{K, V}() where V where K = new(Threads.SpinLock(), true, Dict{K, V}())
    ThreadSafeDict{K, V}(itr) where V where K = new(Threads.SpinLock(), true, Dict{K, V}(itr))
end
ThreadSafeDict() = ThreadSafeDict{Any,Any}()
ThreadSafeDict(d::Dict) = ThreadSafeDict{typeof(d.keys[1]),typeof(d.vals[1])}(d)

function EnableLock(dic::ThreadSafeDict)
    dic.enabled = true
    unlock(dic.dlock)
end

function DisableLock(dic::ThreadSafeDict)
    dic.enabled = false
    lock(dic.dlock)
end

function getindex(dic::ThreadSafeDict, k)
    if dic.enabled
        lock(dic.dlock)
        v = getindex(dic.d, k)
        unlock(dic.dlock)
        return v
    else
        return getindex(dic.d, k)
    end
end

function setindex!(dic::ThreadSafeDict, k, v)
    if dic.enabled
        lock(dic.dlock)
        h = setindex!(dic.d, k, v)
        unlock(dic.dlock)
        return h
    else
        return setindex!(dic.d, k, v)
    end
end

function haskey(dic::ThreadSafeDict, k)
    if dic.enabled
        lock(dic.dlock)
        b = haskey(dic.d, k)
        unlock(dic.dlock)
        return b
    else
        return haskey(dic.d, k)
    end
end

function get(dic::ThreadSafeDict, k, v)
    if dic.enabled
        lock(dic.dlock)
        v = get(dic.d, k, v)
        unlock(dic.dlock)
        return v
    else
        return get(dic.d, k, v)
    end
end

function get!(dic::ThreadSafeDict, k, v)
    if dic.enabled
        lock(dic.dlock)
        v = get!(dic.d, k, v)
        unlock(dic.dlock)
        return v
    else
        return get!(dic.d, k, v)
    end
end

function pop!(dic::ThreadSafeDict)
    if dic.enabled
        lock(dic.dlock)
        p = pop!(dic.d)
        unlock(dic.dlock)
        return p
    else
        return pop!(dic.d)
    end
end

function empty!(dic::ThreadSafeDict)
    if dic.enabled
        lock(dic.dlock)
        d = empty!(dic.d)
        unlock(dic.dlock)
        return d
    else
        return empty!(dic.d)
    end
end

function delete!(dic::ThreadSafeDict, k)
    if dic.enabled
        lock(dic.dlock)
        p = delete!(dic.d, k)
        unlock(dic.dlock)
        return p
    else
        return delete!(dic.d, k)
    end
end

function length(dic::ThreadSafeDict)
    if dic.enabled
        lock(dic.dlock)
        len = length(dic.d)
        unlock(dic.dlock)
        return len
    else
        return length(dic.d)
    end
end

function iterate(dic::ThreadSafeDict)
    if dic.enabled
        lock(dic.dlock)
        p = iterate(dic.d)
        unlock(dic.dlock)
        return p
    else
        return iterate(dic.d)
    end
end

function iterate(dic::ThreadSafeDict, i)
    if dic.enabled
        lock(dic.dlock)
        p = iterate(dic.d, i)
        unlock(dic.dlock)
        return p
    else
        return iterate(dic.d, i)
    end
end  

function print(io::IO, dic::ThreadSafeDict)
    print(io, "Dict was ", islocked(dic.dlock) ? "locked" : "unlocked", ", contents: ")
    lock(dic.dlock)
    print(io, dic.d)
    unlock(dic.dlock)
end

end # module
