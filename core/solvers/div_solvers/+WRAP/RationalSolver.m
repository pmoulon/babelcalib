classdef RationalSolver < WRAP.Solver
    properties
        solver_model = 'rat';
        solver_model_full = 'Rational';
    end
    
    methods
        function this = RationalSolver(mss, varargin)
            this = this@WRAP.Solver(mss, varargin{:});
        end

        function models = fit(this, x, idx, X, varargin)
            if nargin < 3, idx = []; end
            [data, varinput] = this.transform_meas(x, idx, X);
            models = this.solve(data, varinput);
        end

        function res = verify_eqs(this, proj_params, x, idx, X)
            if nargin < 4, idx = []; end
            data = this.transform_meas(x, idx);
            res = this.verify_eqs_(proj_params, data);
        end

        function res = verify_eqs_(this, proj_params, data)
            eqs = this.problem0(proj_params, data);
            res = true;
            if any(abs(eqs) > 1e-5)
                res = false;
            end
        end

        function [eqs,data,eqs_data] = problem(this, data)
            error('Not implemented.')
        end

        function eqs = problem0(this, proj_params, data, int_data)
            error('Not implemented.')
        end
       
        function M = solve(this, data)
            error('Not implemented.')
        end

        function [data, varinput] = transform_meas(this, x, idx, X)
            error('Not implemented.')
        end

        function flag = is_model_good(this, meas, idx, model, varargin)
            flag = this.valid_proj_params(model.proj_params);
        end
    end

    methods(Static)
        function flag = valid_proj_params(params, varargin)
            if numel(params)==2 & ~isempty( varargin) & (params(1)/2/-params(2) > 0)
                rmax = sqrt(params(1)/2/-params(2));
                x = varargin{1};
                flag = rmax > max(vecnorm(x(1:2,:)));
            else
                flag = 1;
            end
            flag = flag & ...
                all(abs(imag(params)) < 1e-9) &...
                all(abs(real(params)) < 2);
        end

        function flag = valid_f(f, varargin)
            flag = abs(imag(f)) < 1e-9 &...
                   real(f) > 1e-9 & real(f) < 5;
        end

        function [models, flag] = valid_models(models, varargin)
            if isfield(models,'K') & ~isempty(varargin)
                x = varargin{1};
                flag = arrayfun(@(m) WRAP.RationalSolver.valid_proj_params(reshape(m.proj_params,1,[]),m.K\x), models);
            else
                flag = arrayfun(@(m) WRAP.RationalSolver.valid_proj_params(reshape(m.proj_params,1,[])), models);
            end
            if isfield(models,'K')
                flag = flag & ...
                arrayfun(@(m) WRAP.RationalSolver.valid_f(m.K(1,1)),models);
            end
            models = models(flag);
        end
    end
end
